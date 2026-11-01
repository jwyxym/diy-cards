-- c01219002.lua
-- 速攻魔法
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- 检查是否必须用全部3张（去掉任意1张后不能融合）
function s.need_all_3(fc,mat,chkf)
	local tc=mat:GetFirst()
	while tc do
		local sub=mat:Clone()
		sub:RemoveCard(tc)
		if fc:CheckFusionMaterial(sub,nil,chkf) then
			return false
		end
		tc=mat:GetNext()
	end
	return true
end

-- 检查：在已选 mat 的基础上，从手卡/场上/卡组补全为满足 fc 的3素材组合
-- need_h/need_m/need_d: 还需从各区域选几只
function s.can_complete(tp,fc,mat,used_attr,need_h,need_m,need_d,chkf)
	local hg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND,0,nil,TYPE_MONSTER)
	local mg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_MONSTER)
	local dg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_DECK,0,nil,TYPE_MONSTER)
	hg:Sub(mat)
	mg:Sub(mat)
	dg:Sub(mat)

	local function rec(cur,cur_attr,n_h,n_m,n_d)
		if n_h==0 and n_m==0 and n_d==0 then
			return fc:CheckFusionMaterial(cur,nil,chkf) and s.need_all_3(fc,cur,chkf)
		end
		if n_h>0 then
			for c in aux.Next(hg) do
				if bit.band(c:GetAttribute(),cur_attr)==0 then
					local nc=cur:Clone()
					nc:AddCard(c)
					if rec(nc,bit.bor(cur_attr,c:GetAttribute()),n_h-1,n_m,n_d) then return true end
				end
			end
		end
		if n_m>0 then
			for c in aux.Next(mg) do
				if bit.band(c:GetAttribute(),cur_attr)==0 then
					local nc=cur:Clone()
					nc:AddCard(c)
					if rec(nc,bit.bor(cur_attr,c:GetAttribute()),n_h,n_m-1,n_d) then return true end
				end
			end
		end
		if n_d>0 then
			for c in aux.Next(dg) do
				if bit.band(c:GetAttribute(),cur_attr)==0 then
					local nc=cur:Clone()
					nc:AddCard(c)
					if rec(nc,bit.bor(cur_attr,c:GetAttribute()),n_h,n_m,n_d-1) then return true end
				end
			end
		end
		return false
	end
	return rec(mat,used_attr,need_h,need_m,need_d)
end

-- 融合怪兽筛选：存在合法3素材组合
function s.filter2(c,e,tp,f,chkf)
	if not (c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then
		return false
	end
	return s.can_complete(tp,c,Group.CreateGroup(),0,1,1,1,chkf)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil,chkf)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,3,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK)
end

-- 选1只素材：从 g 里选，要求选后还能补全
function s.select_mat(tp,g,fc,mat,used_attr,need_h,need_m,need_d,hint,chkf)
	local cg=g:Filter(function(c)
		if bit.band(c:GetAttribute(),used_attr)~=0 then return false end
		local nc=mat:Clone()
		nc:AddCard(c)
		return s.can_complete(tp,fc,nc,bit.bor(used_attr,c:GetAttribute()),need_h,need_m,need_d,chkf)
	end,nil)
	if #cg==0 then return nil end
	Duel.Hint(HINT_SELECTMSG,tp,hint)
	return cg:Select(tp,1,1,nil):GetFirst()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp

	-- 1. 先选融合怪兽
	local sg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,nil,chkf)
	if #sg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=sg:Select(tp,1,1,nil):GetFirst()
	if not tc then return end

	-- 2. 选手卡1只（选后要能补全：场上1+卡组1）
	local mat=Group.CreateGroup()
	local hg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND,0,nil,TYPE_MONSTER)
	local hc=s.select_mat(tp,hg,tc,mat,0,0,1,1,HINTMSG_FMATERIAL,chkf)
	if not hc then return end
	mat:AddCard(hc)
	local used=hc:GetAttribute()

	-- 3. 选场上1只（选后要能补全：卡组1）
	local mg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_MONSTER)
	local mc=s.select_mat(tp,mg,tc,mat,used,0,0,1,HINTMSG_FMATERIAL,chkf)
	if not mc then return end
	mat:AddCard(mc)
	used=bit.bor(used,mc:GetAttribute())

	-- 4. 选卡组1只（选后要能补全：无）
	local dg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_DECK,0,nil,TYPE_MONSTER)
	local dc=s.select_mat(tp,dg,tc,mat,used,0,0,0,HINTMSG_FMATERIAL,chkf)
	if not dc then return end
	mat:AddCard(dc)

	-- 5. 最终检查
	if not tc:CheckFusionMaterial(mat,nil,chkf) then return end
	if not s.need_all_3(tc,mat,chkf) then return end

	-- 6. 融合召唤
	tc:SetMaterial(mat)
	Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()
	Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
end

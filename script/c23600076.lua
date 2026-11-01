-- 天蚀迁移式 (ID: 23600076)
local s,id,o=GetID()
local SET_ECLIPSE=0xd92 -- 「天蚀」字段代码

function s.initial_effect(c)
	-- ①：这张卡也能把自己场上1只昆虫族超量怪兽解放来发动。
	-- 从自己的墓地·除外状态把1只昆虫族·光属性怪兽特殊召唤。
	-- 把怪兽解放来把这张卡发动的场合，可以再让以下效果适用。
	-- ●把1只昆虫族·光属性超量怪兽在那只怪兽上面重叠当作超量召唤从额外卡组特殊召唤，把这张卡在下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- ②：持有这张卡作为素材中的超量怪兽得到以下效果。
	-- ●这张卡不会成为对方的攻击·效果的对象。
	-- 抗攻击对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)

	-- 抗对方效果对象
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end

-- ==================== 可选解放 Cost 判定（1回合只能解放1次） ====================
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsType(TYPE_XYZ) and c:IsReleasable()
		and Duel.GetMZoneCount(tp,c)>0
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 解放判定：本回合未曾解放过 且 场上有合法的昆虫族超量怪兽
	local can_trib=Duel.GetFlagEffect(tp,id)==0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
	if chk==0 then
		-- 发动前提：当前有空格，或者能通过解放怪兽腾出空格
		return ft>0 or can_trib
	end
	e:SetLabel(0)
	local b1=(ft>0)
	local b2=can_trib
	local trib=false

	-- 询问是否解放怪兽发动；若当前满场且允许解放则必须解放怪兽才能发动
	if b1 and b2 then
		trib=Duel.SelectYesNo(tp,aux.Stringid(id,0))
	elseif b2 and not b1 then
		trib=true
	end

	if trib then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
		Duel.Release(g,REASON_COST)
		-- 注册本回合已解放标记（1回合只能解放1次）
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		-- 记录本次发动为解放发动
		e:SetLabel(1)
	end
end

-- ==================== ① 效果：特召与追加超量叠放 ====================
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end

function s.xyzfilter(c,e,tp,mc)
	return c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_XYZ)
		and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_GRAVE+LOCATION_REMOVED
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,loc,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local loc=LOCATION_GRAVE+LOCATION_REMOVED
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,loc,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end

	-- 解放怪兽发动的场合，询问是否适用追加效果
	local tributed=(e:GetLabel()==1)
	if tributed and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) and not tc:IsImmuneToEffect(e) then
		local xg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,e,tp,tc)
		if #xg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=xg:Select(tp,1,1,nil):GetFirst()
			if sc then
				local c=e:GetHandler()
				-- 将特召怪兽作为超量素材重叠
				sc:SetMaterial(Group.FromCards(tc))
				Duel.Overlay(sc,Group.FromCards(tc))
				if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
					sc:CompleteProcedure()
					-- 把本魔法卡在下面重叠作为超量素材
					if c:IsRelateToEffect(e) then
						c:CancelToGrave()
						Duel.Overlay(sc,Group.FromCards(c))
					end
				end
			end
		end
	end
end
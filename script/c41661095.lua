--诸罪律明·罪数融合
local s,id,o=GetID()
function s.initial_effect(c)
	--①●：自己的手卡·场上的怪兽作为融合素材，把1只「罪律」融合怪兽融合召唤。对方场上有卡的场合，自己卡组1只「罪律」怪兽也能作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.fustg)
	e1:SetOperation(s.fusop)
	c:RegisterEffect(e1)
	--①●：自己墓地有「罪律」卡存在的场合，从卡组将同名卡不在自己墓地存在的任意数量的「罪律」通常陷阱送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.sdtg)
	e2:SetOperation(s.sdop)
	c:RegisterEffect(e2)
	--②：将墓地的这张卡除外才能发动，对方场上的怪兽的攻击力·守备力下降自己场上的「罪律」卡数量×1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+2)
	e3:SetCost(s.gycost)
	e3:SetTarget(s.gytg)
	e3:SetOperation(s.gyop)
	c:RegisterEffect(e3)
end
--========== ①A 融合 ==========
function s.fusfilter(c,e,tp)
	return c:IsSetCard(0xe9a) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end
--素材凑得齐（含卡组代替）时才列出该融合怪兽
function s.fusfilter2(c,e,tp,mg,chkf)
	return s.fusfilter(c,e,tp) and c:CheckFusionMaterial(mg,nil,chkf)
end
--手卡·场上的素材（不受这张卡效果影响的怪兽不能作为素材）
function s.mfilter(c,e)
	return not c:IsImmuneToEffect(e)
end
--对方场上有卡的场合，卡组「罪律」怪兽也能作为融合素材
function s.dmatfilter(c)
	return c:IsSetCard(0xe9a) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.zlchk(c)
	return c:IsSetCard(0xe9a) or c:IsCode(41661075)
end
--卡组素材最多1只
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
--组装素材候选：自己的手卡·场上；对方场上有卡的场合并入卡组素材
function s.getmat(tp,e)
	local mg=Duel.GetFusionMaterial(tp):Filter(s.mfilter,nil,e)
	local ex=false
	if Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)>0 then
		local dg=Duel.GetMatchingGroup(s.dmatfilter,tp,LOCATION_DECK,0,nil)
		if dg:GetCount()>0 then
			mg:Merge(dg)
			ex=true
		end
	end
	return mg,ex
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=tp
	local mg,ex=s.getmat(tp,e)
	if ex then
		aux.FCheckAdditional=s.fcheck
		aux.GCheckAdditional=s.gcheck
	end
	local res=Duel.IsExistingMatchingCard(s.fusfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,chkf)
	aux.FCheckAdditional=nil
	aux.GCheckAdditional=nil
	if chk==0 then return res end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg,ex=s.getmat(tp,e)
	if ex then
		aux.FCheckAdditional=s.fcheck
		aux.GCheckAdditional=s.gcheck
	end
	local sg=Duel.GetMatchingGroup(s.fusfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,chkf)
	aux.FCheckAdditional=nil
	aux.GCheckAdditional=nil
	if sg:GetCount()==0 then return end
	--选择要融合召唤的「罪律」融合怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=sg:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	mg:RemoveCard(tc)
	--官方界面：一次窗口内选完全部素材（卡组素材最多1只）
	if ex then
		aux.FCheckAdditional=s.fcheck
		aux.GCheckAdditional=s.gcheck
	end
	local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
	aux.FCheckAdditional=nil
	aux.GCheckAdditional=nil
	if not mat or mat:GetCount()==0 then return end
	tc:SetMaterial(mat)
	Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()
	Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
end
--========== ①B 陷阱送墓 ==========
function s.sdfilter(c,tp)
	return c:IsSetCard(0xe9a) and c:IsType(TYPE_TRAP) and not c:IsType(TYPE_CONTINUOUS+TYPE_COUNTER)
		and c:IsAbleToGrave()
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function s.sdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.zlchk,tp,LOCATION_GRAVE,0,1,nil)
			and Duel.IsExistingMatchingCard(s.sdfilter,tp,LOCATION_DECK,0,1,nil,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.sdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.sdfilter,tp,LOCATION_DECK,0,nil,tp)
	if g:GetCount()==0 then return end
	--同名卡最多只能送墓1张
	local codes={}
	local cg=Group.CreateGroup()
	for tc in aux.Next(g) do
		local code=tc:GetCode()
		if not codes[code] then
			codes[code]=true
			cg:AddCard(tc)
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sg=cg:Select(tp,1,cg:GetCount(),nil)
	if sg:GetCount()>0 then
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
--========== ② 攻守下降 ==========
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMatchingGroupCount(s.zlchk,tp,LOCATION_ONFIELD,0,nil)>0
			and Duel.IsExistingMatchingCard(Card.IsFaceup,1-tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,1-tp,LOCATION_MZONE)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.zlchk,tp,LOCATION_ONFIELD,0,nil)
	if ct<=0 then return end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,1-tp,LOCATION_MZONE,0,nil)
	if g:GetCount()==0 then return end
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000*ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end

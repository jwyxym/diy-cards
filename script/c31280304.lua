--深池之狂 蔓德拉
function c31280304.initial_effect(c)
	aux.AddCodeList(c,31280321)
	c:EnableReviveLimit()
	--仪式召唤
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(31280304,0))
    e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,31280304)
    e1:SetCondition(c31280304.condition)
	e1:SetTarget(c31280304.target)
	e1:SetOperation(c31280304.operation)
	c:RegisterEffect(e1)
	--怪兽覆盖
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(31280304,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,31280304)
	e2:SetCondition(c31280304.condition)
    e2:SetCost(c31280304.cost1)
	e2:SetTarget(c31280304.target1)
	e2:SetOperation(c31280304.operation1)
	c:RegisterEffect(e2)
	--效破抗性
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(c31280304.condition2)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
    --特召回合
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(c31280304.operation3)
	c:RegisterEffect(e4)
	--陷阱盖放
	local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(31280304,2))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,31380304)
	e5:SetCondition(c31280304.condition4)
	e5:SetTarget(c31280304.target4)
	e5:SetOperation(c31280304.operation4)
	c:RegisterEffect(e5)
end
function c31280304.condition(e,tp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
		and e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN)
end
function c31280304.filter(c,e,tp)
	return c:IsCode(31280305)
end
function c31280304.RitualUltimateFilter(c,filter,e,tp,m1,m2,level_function,greater_or_equal,chk)
	if bit.band(c:GetType(),0x81)~=0x81 or (filter and not filter(c,e,tp,chk)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true,POS_FACEUP) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	if m2 then
		mg:Merge(m2)
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	else
		mg:RemoveCard(c)
	end
	local lv=level_function(c)
	aux.GCheckAdditional=aux.RitualCheckAdditional(c,lv,greater_or_equal)
	local res=mg:CheckSubGroup(aux.RitualCheck,1,lv,tp,c,lv,greater_or_equal)
	aux.GCheckAdditional=nil
	return res
end
function c31280304.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    if chk==0 then
		local mg1=Duel.GetRitualMaterial(tp)
        return Duel.IsExistingMatchingCard(c31280304.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,c31280304.filter,e,tp,mg1,nil,Card.GetLevel,"Greater") 
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function c31280304.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	::cancel::
    local mg1=Duel.GetRitualMaterial(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31280304.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,c31280304.filter,e,tp,mg1,nil,Card.GetLevel,"Greater")
	local tc=g:GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
function c31280304.poscostfilter1(c)
	return c:IsAbleToRemoveAsCost() and c:IsType(TYPE_SPELL)
end
function c31280304.poscostfilter2(c)
	return c:IsAbleToRemoveAsCost() and c:IsType(TYPE_TRAP)
end
function c31280304.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280304.poscostfilter1,tp,LOCATION_GRAVE,0,1,e:GetHandler())
		and Duel.IsExistingMatchingCard(c31280304.poscostfilter2,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sg=Duel.SelectMatchingCard(tp,c31280304.poscostfilter1,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	local sg2=Duel.SelectMatchingCard(tp,c31280304.poscostfilter2,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	Duel.Remove(sg+sg2,POS_FACEUP,REASON_COST)
end
function c31280304.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsType(TYPE_EFFECT)
end
function c31280304.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c31280304.posfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c31280304.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,c31280304.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function c31280304.operation1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
        if tc:IsPosition(POS_FACEDOWN_DEFENSE) then
        	local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
        end       
	end
end
function c31280304.condition2(e)
	return e:GetHandler():IsDefensePos()
end
function c31280304.operation3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(31280304,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function c31280304.condition4(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(31280304)>0
end
function c31280304.stfilter(c)
	return c:IsSetCard(0xca3) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function c31280304.target4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(c31280304.stfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function c31280304.operation4(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,c31280304.stfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
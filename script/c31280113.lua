--极炎龙骑士·洛乐
function c31280113.initial_effect(c)
	c:SetSPSummonOnce(31280113)
	c:EnableReviveLimit()
	aux.EnablePendulumAttribute(c)
	--特召条件
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	--展示机械族和龙族，效果无效
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31280113,2))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(c31280113.condition)
	e3:SetOperation(c31280113.operation)
	c:RegisterEffect(e3)
	--种族视为机械族    
    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_ADD_RACE)
	e5:SetRange(LOCATION_MZONE+LOCATION_EXTRA+LOCATION_HAND)
	e5:SetValue(RACE_MACHINE)
	c:RegisterEffect(e5)
	--仪式召唤    
    local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetRange(LOCATION_EXTRA)
	e6:SetCondition(c31280113.condition3)
	e6:SetTarget(c31280113.target3)
	e6:SetOperation(c31280113.operation3)
	c:RegisterEffect(e6)
    local e7=e6:Clone()
	e7:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e7)
	--展示机械族，攻击上升和多次攻击       
    local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(31280113,0))
	e8:SetCategory(CATEGORY_ATKCHANGE)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCode(EVENT_SPSUMMON_SUCCESS)
    e8:SetCountLimit(1,31380113)
	e8:SetCost(c31280113.cost)
	e8:SetOperation(c31280113.operation4)
	c:RegisterEffect(e8)
	--展示龙族，卡片送墓    
    local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(31280113,1))
	e9:SetCategory(CATEGORY_TOGRAVE)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e9:SetProperty(EFFECT_FLAG_DELAY)
	e9:SetCode(EVENT_SPSUMMON_SUCCESS)
    e9:SetCountLimit(1,31380113)
	e9:SetCost(c31280113.cost1)
    e9:SetTarget(c31280113.target5)
	e9:SetOperation(c31280113.operation5)
	c:RegisterEffect(e9)
	--展示机械族和龙族，延时破坏
    local e10=Effect.CreateEffect(c)
	e10:SetDescription(aux.Stringid(31280113,2))
	e10:SetCategory(CATEGORY_DESTROY)
	e10:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e10:SetProperty(EFFECT_FLAG_DELAY)
	e10:SetCode(EVENT_SPSUMMON_SUCCESS)
    e10:SetCountLimit(1,31380113)
	e10:SetCost(c31280113.cost2)
	e10:SetOperation(c31280113.operation6)
	c:RegisterEffect(e10)
end
function c31280113.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainDisablable(ev) and re:IsActiveType(TYPE_MONSTER) and Duel.GetCurrentChain()>=2 
    	and Duel.IsExistingMatchingCard(c31280113.cfilter2,tp,LOCATION_HAND,0,2,nil) and Duel.GetFlagEffect(tp,31280113)==0
end
function c31280113.operation(e,tp,eg,ep,ev,re,r,rp)	
	local c=e:GetHandler()
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(31280113,3)) then
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.GetMatchingGroup(c31280113.cfilter2,tp,LOCATION_HAND,0,nil)
        g:CheckSubGroup(aux.gfcheck,2,2,Card.IsRace,RACE_MACHINE,RACE_DRAGON)
        local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsRace,RACE_MACHINE,RACE_DRAGON)
    	if sg then                  
        	Duel.ConfirmCards(1-tp,sg)		
			Duel.ShuffleHand(tp)
            Duel.Hint(HINT_CARD,0,31280113)
  			if Duel.NegateEffect(ev) then
        		Duel.Destroy(c,REASON_EFFECT)
            end                	
		end
        Duel.RegisterFlagEffect(tp,31280113,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
function c31280113.cfilter(c)
	return c:IsRace(RACE_MACHINE) and not c:IsPublic()
end
function c31280113.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280113.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,c31280113.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function c31280113.cfilter1(c)
	return c:IsRace(RACE_DRAGON) and not c:IsPublic()
end
function c31280113.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280113.cfilter1,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,c31280113.cfilter1,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function c31280113.cfilter2(c)
	return c:IsRace(RACE_MACHINE+RACE_DRAGON) and not c:IsPublic()
end
function c31280113.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c31280113.cfilter2,tp,LOCATION_HAND,0,nil)
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsRace,RACE_MACHINE,RACE_DRAGON) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsRace,RACE_MACHINE,RACE_DRAGON)
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleHand(tp)
end
function c31280113.spcfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER>0 and c:IsReason(REASON_EFFECT)
end
function c31280113.condition3(e,tp,eg,ep,ev,re,r,rp)
	return re and eg:IsExists(c31280113.spcfilter,1,nil)
end
function c31280113.rfilter(c,tp,ec)
	return c:IsRace(RACE_DRAGON+RACE_MACHINE) and c:IsReleasableByEffect()
		and c:IsLevelAbove(10) and c:IsType(TYPE_MONSTER)
		and Duel.GetLocationCountFromEx(tp,tp,c,ec)>0
end
function c31280113.target3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c31280113.rfilter,tp,LOCATION_MZONE,0,c,tp,c)
	if chk==0 then return #g>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c31280113.operation3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,c31280113.rfilter,tp,LOCATION_MZONE,0,1,1,aux.ExceptThisCard(e),tp,c)
	if Duel.Release(g,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,SUMMON_TYPE_RITUAL,tp,tp,true,true,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
function c31280113.operation4(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ATTACK_ALL)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
    end
end
function c31280113.target5(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
function c31280113.operation5(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
function c31280113.operation6(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(c31280113.operation7)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c31280113.operation7(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,31280113)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
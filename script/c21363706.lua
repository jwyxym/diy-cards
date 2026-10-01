--盗贼浮世绘·路见不平
function c21363706.initial_effect(c)
	aux.AddCodeList(c,21363700)
	--Activate
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)  
	c:RegisterEffect(e1)
	--SpecialSummon
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE) 
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN) 
	e1:SetTarget(c21363706.settg)
	e1:SetOperation(c21363706.setop)
	c:RegisterEffect(e1)  
	--
	local e2=Effect.CreateEffect(c)  
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_REMOVE) 
	e2:SetTarget(c21363706.rsettg)
	e2:SetOperation(c21363706.rsetop)
	c:RegisterEffect(e2)
	--Activate 
	--local e1=Effect.CreateEffect(c) 
	--e1:SetCategory(CATEGORY_SUMMON+CATEGORY_SPECIAL_SUMMON)
	--e1:SetType(EFFECT_TYPE_ACTIVATE)
	--e1:SetCode(EVENT_FREE_CHAIN) 
	--e1:SetTarget(c21363706.actg)
	--e1:SetOperation(c21363706.acop)
	--c:RegisterEffect(e1) 
	--destroy
	--local e2=Effect.CreateEffect(c) 
	--e2:SetCategory(CATEGORY_DESTROY)
	--e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	--e2:SetCode(EVENT_REMOVE)
	--e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET) 
	--e2:SetTarget(c21363706.destg)
	--e2:SetOperation(c21363706.desop)
	--c:RegisterEffect(e2)
	--act in hand
	--local e2=Effect.CreateEffect(c)
	--e2:SetDescription(aux.Stringid(21363706,0))
	--e2:SetType(EFFECT_TYPE_SINGLE)
	--e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	--e2:SetCondition(c21363706.handcon)
	--c:RegisterEffect(e2) 
	--act in set turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetDescription(aux.Stringid(21363706,0))
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCost(c21363706.cost)
	c:RegisterEffect(e0)
end
function c21363706.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) end 
	local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil) 
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)  
end
function c21363706.setfil(c)
	return not c:IsCode(21363706) and aux.IsCodeListed(c,21363700) and c:IsSSetable() and c:IsType(TYPE_TRAP)
end
function c21363706.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21363706.setfil,tp,LOCATION_DECK,0,1,nil) end 
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
function c21363706.rmfil(c) 
	return c:IsAbleToRemove() and c:IsType(TYPE_TRAP) 
end 
function c21363706.rdesfil(c,e,tp) 
	local b1=c:IsLevelAbove(1) and Duel.IsExistingMatchingCard(c21363706.rmfil,tp,LOCATION_GRAVE,0,c:GetLevel(),nil)
	local b2=c:IsRankAbove(1) and Duel.IsExistingMatchingCard(c21363706.rmfil,tp,LOCATION_GRAVE,0,c:GetRank(),nil)
	return c:IsFaceup() and (b1 or b2) 
end  
function c21363706.setop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0) then return end 
	local tc=Duel.SelectMatchingCard(tp,c21363706.setfil,tp,LOCATION_DECK,0,1,1,nil):GetFirst() 
	if tc and Duel.SSet(tp,tc)~=0 and Duel.IsExistingMatchingCard(c21363706.rdesfil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(21363706,2)) then 
		Duel.BreakEffect() 
		local dc=Duel.SelectMatchingCard(tp,c21363706.rdesfil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp):GetFirst() 
		local x=0
		if c:IsRankAbove(1) then x=c:GetRank() end 
		if c:IsLevelAbove(1) then x=c:GetLevel() end 
		local rg=Duel.SelectMatchingCard(tp,c21363706.rmfil,tp,LOCATION_GRAVE,0,x,x,nil) 
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT) 
	end 
end 
function c21363706.rsettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end 
end
function c21363706.rsetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SSet(tp,c) 
	end
end

function c21363706.handcon(e)
	return Duel.IsExistingMatchingCard(c21363706.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function c21363706.filter(c)
	return c:IsFaceup() and c:IsCode(21363700) 
end
function c21363706.sumfil(c)
	return c:IsSummonable(true,nil) and c:IsAttribute(ATTRIBUTE_WIND)
end 
function c21363706.csetfil(c,e,tp)
	return c:IsCode(21363700) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end 
function c21363706.actg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local b1=Duel.IsExistingMatchingCard(c21363706.sumfil,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(c21363706.csetfil,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	if chk==0 then return b1 or b2 end  
end
function c21363706.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local b1=Duel.IsExistingMatchingCard(c21363706.sumfil,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(c21363706.csetfil,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	local res=false 
	if b1 and Duel.SelectYesNo(tp,aux.Stringid(21363706,1)) then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local sc=Duel.SelectMatchingCard(tp,c21363706.sumfil,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
		if sc then
			Duel.Summon(tp,sc,true,nil)
		end  
		res=true 
	end 
	if b2 and Duel.SelectYesNo(tp,aux.Stringid(21363706,2)) then 
		if res then 
			Duel.BreakEffect() 
		end 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,c21363706.csetfil,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst() 
		if tc then 
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) 
		end 
	end 
end
function c21363706.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c21363706.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

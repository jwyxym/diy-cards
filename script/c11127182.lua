--永瞬华彩·日染新生
function c11127182.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,function(c) return c:IsFusionSetCard(0xa62) and c:IsFusionType(TYPE_MONSTER) end,2,true)  
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_MZONE+LOCATION_GRAVE,0,Duel.Remove,POS_FACEUP,REASON_COST):SetValue(SUMMON_TYPE_FUSION)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(function(e,se,sp,st)
	return se:GetHandler():IsSetCard(0xa62) end) 
	c:RegisterEffect(e1) 
	--Destroy 
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY) 
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1) 
	e1:SetCondition(c11127182.descon) 
	e1:SetTarget(c11127182.destg)
	e1:SetOperation(c11127182.desop)
	c:RegisterEffect(e1)  
	--search
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TOHAND) 
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O) 
	e2:SetCode(EVENT_REMOVE) 
	e2:SetProperty(EFFECT_FLAG_DELAY) 
	e2:SetCountLimit(1,21127182) 
	e2:SetTarget(c11127182.thtg)
	e2:SetOperation(c11127182.thop)
	c:RegisterEffect(e2) 
end
function c11127182.gckfil(c,tp) 
	return c:IsPreviousControler(tp) and c:IsSetCard(0xa62) and c:IsType(TYPE_MONSTER)  
end 
function c11127182.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c11127182.gckfil,1,nil,tp) and e:GetHandler():GetFlagEffect(11127182)==0 
end  
function c11127182.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end 
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end 
function c11127182.rmfil(c) 
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsRace(RACE_PLANT+RACE_INSECT) and c:IsAbleToRemove() 
end 
function c11127182.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa62) and c:IsType(TYPE_FUSION) and c:IsLevelAbove(5) 
end
function c11127182.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsAbleToRemove() and Duel.IsExistingMatchingCard(c11127182.cfilter,tp,LOCATION_MZONE,0,1,nil) then 
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) 
		else 
			Duel.Destroy(tc,REASON_EFFECT)  
		end 
	end 
	if c:IsRelateToEffect(e) then
		c:RegisterFlagEffect(11127182,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
function c11127182.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa62) and c:IsAbleToHand()
end
function c11127182.thgck(g) 
	return g:IsExists(c11127182.thfilter,1,nil) 
end 
function c11127182.thtg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_REMOVED,0,nil)
	if chk==0 then return g:CheckSubGroup(c11127182.thgck,2,2) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,PLAYER_ALL,LOCATION_REMOVED)
end
function c11127182.thop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_REMOVED,0,nil) 
	if g:CheckSubGroup(c11127182.thgck,2,2) then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:SelectSubGroup(tp,c11127182.thgck,false,2,2)
		Duel.SendtoHand(sg,nil,REASON_EFFECT) 
	end  
end







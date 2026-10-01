--蛛丝的诡姬 莎木·纳克雅
function c38030153.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcCodeFunRep(c,38030168,c38030153.matfilter,2,283,true,true)
	--spsummon success
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	--e1:SetCondition(c38030153.atkcon)
	e1:SetOperation(c38030153.atkop)
	c:RegisterEffect(e1)
	--change effect type
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(38030153)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c38030153.efcon)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	--to hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(38030153,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c38030153.thtg)
	e4:SetOperation(c38030153.thop)
	c:RegisterEffect(e4)
end
function c38030153.matfilter(c,fc,sub,mg,sg)
	local tc=sg:Filter(Card.IsFusionCode,nil,38030168):GetFirst()
	return c:IsFusionType(TYPE_EFFECT) and (not sg or not sg:Filter(Card.IsFusionType,tc,TYPE_EFFECT):IsExists(Card.IsFusionSetCard,1,nil,0x5616))
end
function c38030153.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(c:GetMaterialCount()*800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e2)
end
function c38030153.efcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function c38030153.thfilter(c,e,tp)
	return c:IsSetCard(0x5616) and ((c:IsType(TYPE_SPELL+TYPE_TRAP) and (c:IsAbleToHand() or c:IsSSetable())) or (c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or (c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and Duel.GetMZoneCount(tp)>0))))
end
function c38030153.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c38030153.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
function c38030153.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local tc=Duel.SelectMatchingCard(tp,c38030153.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc:IsType(TYPE_SPELL+TYPE_TRAP) then
		if tc:IsAbleToHand() and (not tc:IsSSetable() or Duel.SelectOption(tp,1190,1153)==0) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SSet(tp,tc)
		end
	else
		if tc:IsAbleToHand() and (not (tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and Duel.GetMZoneCount(tp)>0) or Duel.SelectOption(tp,1190,1153)==0) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end

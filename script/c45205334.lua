--融合次元的中心之城
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	
	--①效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	
	--②效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(s.fuscost)
	e2:SetTarget(s.fustg)
	e2:SetOperation(s.fusop)
	c:RegisterEffect(e2)
	
	--③效果：墓地有「融合」时，自己场上的融合怪兽不受对方的魔法效果影响，攻击力上升700
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.fustg2)
	e3:SetCondition(s.fuscon)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	local e3d=Effect.CreateEffect(c)
	e3d:SetType(EFFECT_TYPE_FIELD)
	e3d:SetCode(EFFECT_UPDATE_ATTACK)
	e3d:SetRange(LOCATION_FZONE)
	e3d:SetTargetRange(LOCATION_MZONE,0)
	e3d:SetTarget(s.fustg2)
	e3d:SetCondition(s.fuscon)
	e3d:SetValue(700)
	c:RegisterEffect(e3d)
end

function s.fuscon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,24094653)
end

function s.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.fuscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND,0,1,nil,24094653) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_HAND,0,1,1,nil,24094653)
	Duel.ConfirmCards(1-tp,g)
end

function s.fusfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and c:IsCanBeFusionMaterial()
end

function s.fuscheck(c,e,tp,mg,chkf)
	return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(mg,nil,chkf)
end

function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=tp
	local mg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fuscheck,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,chkf) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE+LOCATION_GRAVE)
end

function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	local g=Duel.GetMatchingGroup(s.fuscheck,tp,LOCATION_EXTRA,0,nil,e,tp,mg,chkf)
	if g:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:Select(tp,1,1,nil)
	local sc=sg:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local mat=Duel.SelectFusionMaterial(tp,sc,mg,nil,chkf)
	sc:SetMaterial(mat)
	Duel.HintSelection(mat)
	Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	Duel.BreakEffect()
	Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	sc:CompleteProcedure()
end

function s.fustg2(e,c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end

function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_SPELL)
end

return s
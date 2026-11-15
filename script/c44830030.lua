--人灭富豪
local s,id,o=GetID()
local RENMIE=0x7ce1
local SHEN=57330010

function s.initial_effect(c)
	aux.AddCodeList(c,SHEN)
	--①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「人灭富豪」以外的1只「人灭」怪兽加入手卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--②：卡为让「人灭」卡的效果发动而从手卡·场上·墓地除外的场合，可以从以下效果选择1个发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+1000)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--共通：这张卡的效果发动的回合，自己不是恶魔族怪兽不能特殊召唤
function s.reglimit(e,tp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	if not c:IsRace(RACE_FIEND) then return true end
	if not c:IsType(TYPE_FUSION) then return false end
	--不用卡的效果的特殊召唤（接触融合等召唤规则）也禁止
	return se==nil or se:GetCode()==EFFECT_SPSUMMON_PROC
end

--①
function s.thfilter(c)
	return c:IsSetCard(RENMIE) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	s.reglimit(e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--②
function s.rmfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	--代价除外，或「人灭执事」作为那1张卡的代替除外
	if r&(REASON_COST+REASON_REPLACE)==0 then return false end
	--发动源不是「人灭」卡则不处理（拿不到发动源时不作限制）
	local rc=re and re:GetHandler()
	if rc and not rc:IsSetCard(RENMIE) then return false end
	return eg:IsExists(s.rmfilter,1,nil,tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(RENMIE) and c:IsType(TYPE_MONSTER) and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thfilter2(c)
	return ((c:IsSetCard(RENMIE) and c:IsType(TYPE_SPELL+TYPE_TRAP)) or c:IsCode(SHEN))
		and c:IsAbleToHand()
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,nil,e,tp)
		local b2=Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		if not b1 and not b2 then return false end
		e:SetLabel((b1 and 1 or 0)+(b2 and 2 or 0))
		return true
	end
	s.reglimit(e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local lab=e:GetLabel()
	local ops={}
	if lab%2==1 then ops[#ops+1]=0 end
	if lab>=2 then ops[#ops+1]=1 end
	if #ops==0 then return end
	local op=ops[1]
	if #ops>1 then
		op=ops[Duel.SelectOption(tp,aux.Stringid(id,8),aux.Stringid(id,9))+1]
	end
	if op==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

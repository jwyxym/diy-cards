-- 云之道（ID: 61000056）场地魔法
-- 效果文本：
--   这个卡名在规则上也当作「云剑」卡使用。这个卡名的卡1回合只能发动1张。
--   ①：作为这张卡发动时的效果处理，可以从卡组选1张「云剑」卡送去墓地（这个效果发动的回合，自己若非不能通常召唤的怪兽则不能特殊召唤，也不能把那个的怪兽效果发动）。
--   ②：1回合1次，自己在连锁2以后把「云剑」卡的效果发动的场合，可以让自己手卡·场上的1张陷阱卡送去墓地，从卡组抽1张。
--   ③：每次自己把「云剑」卡的效果发动，自己场上守备表示的怪兽的守备力上升400，自己场上没有怪兽存在的场合，把1只「云影衍生物」特殊召唤。
local s,id,o=GetID()
s.setcode=0xa7c0

function s.initial_effect(c)
	-- ① 发动时：堆1张「云剑」卡 + 自肃
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)

	-- ② 1回合1次：连锁2以后自己发动「云剑」卡的效果时，处理时询问
	--    参考 06798031（雷火沸动交界机）③：CONTINUOUS + EVENT_CHAIN_SOLVING + SelectEffectYesNo
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE+LOCATION_FZONE)
	e2:SetCondition(s.con2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)

	-- ③ 每次自己发动「云剑」卡的效果：守备力+400 / 出衍生物
	--    适用效果：不入连锁、不询问，直接处理（TRIGGER_F 会自己连锁自己）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE+LOCATION_FZONE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCondition(s.con3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end

function s.qfilter(c)
	return c:IsSetCard(s.setcode) and c:IsAbleToGrave()
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	s.applylimit(e,tp)
	if Duel.GetMatchingGroupCount(s.qfilter,tp,LOCATION_DECK,0,nil)==0 then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.qfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end

-- 自肃：只能特召不能通常召唤的怪兽；不能把怪兽效果发动
function s.applylimit(e,tp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.actlimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

-- 与 22420202 同款检测
function s.splimit(e,c)
	return c:IsSummonableCard() and c:GetOriginalType()&(TYPE_SPELL|TYPE_TRAP|TYPE_TRAPMONSTER)==0
end

function s.actlimit(e,re,rp)
	local h=re:GetHandler()
	return h~=nil and h:IsType(TYPE_MONSTER) and h:IsSummonableCard()
end

-- ②：正在处理的这条连锁是2以上，且是自己在处理「云剑」卡的效果
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	if ev<2 or re==nil then return false end
	local h=re:GetHandler()
	if h==nil or not h:IsSetCard(s.setcode) or h:GetControler()~=tp then return false end
	if e:GetHandler():GetFlagEffect(id)>0 then return false end
	return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,1)
end

function s.costfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToGraveAsCost()
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	if g:GetCount()==0 then return end
	Duel.Hint(HINT_CARD,0,id)
	Duel.SendtoGrave(g,REASON_EFFECT)
	Duel.Draw(tp,1,REASON_EFFECT)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
end

-- ③
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	if re==nil then return false end
	local h=re:GetHandler()
	return h~=nil and h:IsSetCard(s.setcode) and h:GetControler()==tp
end

function s.bufffilter(c)
	return c:IsFaceup() and c:IsPosition(POS_FACEUP_DEFENSE)
end

function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.bufffilter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 自己场上没有怪兽的场合：本次连锁组建中不能特招，
	-- 改成等这次连锁处理完（EVENT_CHAIN_END）再特招
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local ed=Effect.CreateEffect(e:GetHandler())
	ed:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ed:SetCode(EVENT_CHAIN_END)
	ed:SetOperation(s.tokop)
	ed:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ed,tp)
end

function s.tokop(e,tp,eg,ep,ev,re,r,rp)
	e:Reset()
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local token=Duel.CreateToken(tp,61000054)
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e2)
end

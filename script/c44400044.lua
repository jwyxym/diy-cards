-- 晶簇涌动 (ID: 44400044)
local s,id,o=GetID()
local SET_YE_CU=0x97f           -- 「业簇」字段
local SET_CRYSTAL_FLOWER=0x68f  -- 「水晶花」字段
local CARD_DINATO_TUNA=44400046 -- 「狄娜托·图娜」

function s.initial_effect(c)
	aux.AddCodeList(c,CARD_DINATO_TUNA)

	-- 规则效果：这个卡名在规则上也当做「业簇」卡使用
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(SET_YE_CU)
	c:RegisterEffect(e0)

	-- 手卡发动：自己场上存在「狄娜托·图娜」的场合，这张卡可以从手卡发动
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_SINGLE)
	e0b:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0b:SetCondition(s.handcon)
	c:RegisterEffect(e0b)

	-- 卡的发动 / 激活处理（支持手卡/盖放时直接执行 ① 或 ②，声明取对象属性）
	local e_act=Effect.CreateEffect(c)
	e_act:SetType(EFFECT_TYPE_ACTIVATE)
	e_act:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e_act:SetCode(EVENT_FREE_CHAIN)
	e_act:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
	e_act:SetTarget(s.acttg)
	e_act:SetOperation(s.actop)
	c:RegisterEffect(e_act)

	-- ①：场上表侧发动的①效果（二速特召）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)

	-- ②：场上表侧发动的②效果（二速变身装备卡）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_END_PHASE)
	e2:SetTarget(s.eqtg2)
	e2:SetOperation(s.eqop2)
	c:RegisterEffect(e2)

	-- ③：结束阶段发动。魔法陷阱区域表侧表示的这张卡返回持有者的手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.thcon3)
	e3:SetTarget(s.thtg3)
	e3:SetOperation(s.thop3)
	c:RegisterEffect(e3)
end

--------------------------------------------------------------------------------
-- 手卡发动条件（彻底修复：原生判断，绝不调用未定义的 FaceupFilter）
--------------------------------------------------------------------------------
function s.handfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_DINATO_TUNA)
end

function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.handfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

--------------------------------------------------------------------------------
-- 卡的发动分支处理（彻底解决手卡发动与一回合选发其中1次限制）
--------------------------------------------------------------------------------
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==2 then
			return s.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		end
		return false
	end
	local b1=Duel.GetFlagEffect(tp,id)==0 and s.sptg1(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=Duel.GetFlagEffect(tp,id)==0 and s.eqtg2(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return true end

	local op=0
	local options={}
	table.insert(options,aux.Stringid(id,2)) -- 仅把这张卡在场上发动 (0)
	if b1 then table.insert(options,aux.Stringid(id,0)) end -- (1: 特召)
	if b2 then table.insert(options,aux.Stringid(id,1)) end -- (2: 装备)
	local sel=Duel.SelectOption(tp,table.unpack(options))
	if options[sel+1]==aux.Stringid(id,0) then
		op=1
	elseif options[sel+1]==aux.Stringid(id,1) then
		op=2
	end
	e:SetLabel(op)

	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION)
		s.sptg1(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==2 then
		e:SetCategory(CATEGORY_EQUIP)
		s.eqtg2(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(0)
	end
end

function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		s.spop1(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.eqop2(e,tp,eg,ep,ev,re,r,rp)
	end
end

--------------------------------------------------------------------------------
-- ① 效果：特召手卡·墓地「水晶花」怪兽或「狄娜托·图娜」
--------------------------------------------------------------------------------
function s.spfilter1(c,e,tp)
	return (c:IsSetCard(SET_CRYSTAL_FLOWER) or c:IsCode(CARD_DINATO_TUNA))
		and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFlagEffect(tp,id)==0
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--------------------------------------------------------------------------------
-- ② 效果：变身装备卡，赋予对象抗性与魔陷各1次无效
--------------------------------------------------------------------------------
function s.eqfilter2(c)
	return c:IsFaceup() and c:IsCode(CARD_DINATO_TUNA)
end

function s.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter2(chkc) end
	if chk==0 then
		local c=e:GetHandler()
		-- 从手卡发动时需要空余魔陷格，已在魔陷区时直接变身无需空余格
		local ft_check = not c:IsLocation(LOCATION_HAND) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		return Duel.GetFlagEffect(tp,id)==0 and ft_check
			and Duel.IsExistingTarget(s.eqfilter2,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.eqfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

function s.eqop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	if Duel.Equip(tp,c,tc) then
		-- 装备限制
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)

		-- ●装备怪兽不会成为效果对象
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)

		-- ●装备怪兽有２张以上的装备卡装备的场合对方把魔法·陷阱卡发动时才能发动。那个发动无效。
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,3))
		e3:SetCategory(CATEGORY_NEGATE)
		e3:SetType(EFFECT_TYPE_QUICK_O)
		e3:SetCode(EVENT_CHAINING)
		e3:SetRange(LOCATION_SZONE)
		e3:SetCondition(s.negcon)
		e3:SetCost(s.negcost)
		e3:SetTarget(s.negtg)
		e3:SetOperation(s.negop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	end
end

function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not (ec and ec:GetEquipCount()>=2 and rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)) then
		return false
	end
	if re:IsActiveType(TYPE_SPELL) and Duel.GetFlagEffect(tp,id+100)>0 then return false end
	if re:IsActiveType(TYPE_TRAP) and Duel.GetFlagEffect(tp,id+200)>0 then return false end
	return true
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if re:IsActiveType(TYPE_SPELL) then
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
	elseif re:IsActiveType(TYPE_TRAP) then
		Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE+PHASE_END,0,1)
	end
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end

--------------------------------------------------------------------------------
-- ③ 效果：结束阶段必发回手
--------------------------------------------------------------------------------
function s.thcon3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_SZONE)
end

function s.thtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

function s.thop3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end